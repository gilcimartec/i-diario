class IeducarSynchronizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options unique: :until_and_while_executing, retry: false, dead: false

  def perform(entity_id = nil, synchronization_id = nil)
    if entity_id && synchronization_id
      perform_for_entity(
        Entity.find(entity_id),
        synchronization_id
      )
    else
      all_entities.each do |entity|
        entity.using_connection do
          configuration = IeducarApiConfiguration.current
          next unless configuration.persisted?

          synchronization = IeducarApiSynchronization.started.first ||
            configuration.start_synchronization(User.first)

          next if synchronization.running?

          jid = IeducarSynchronizerWorker.perform_in(
            5.seconds,
            entity.id,
            synchronization.id
          )

          synchronization.update(job_id: jid)
        end
      end
    end
  end

  private

  BASIC_SYNCHRONIZERS = [
    KnowledgeAreasSynchronizer.to_s,
    DisciplinesSynchronizer.to_s,
    StudentsSynchronizer.to_s,
    DeficienciesSynchronizer.to_s,
    RoundingTablesSynchronizer.to_s,
    RecoveryExamRulesSynchronizer.to_s,
    CoursesGradesClassroomsSynchronizer.to_s,
    TeachersSynchronizer.to_s,
    StudentEnrollmentDependenceSynchronizer.to_s
  ].freeze

  def perform_for_entity(entity, synchronization_id)
    entity.using_connection do
      begin
        synchronization = IeducarApiSynchronization.find(synchronization_id)

        break unless synchronization.started?

        worker_batch = WorkerBatch.find_or_create_by!(
          main_job_class: IeducarSynchronizerWorker.to_s,
          main_job_id: synchronization.job_id
        )
        worker_batch.start!

        total_in_batch = []

        total BASIC_SYNCHRONIZERS.size
        BASIC_SYNCHRONIZERS.each_with_index do |klass, index|
          at(index + 1, klass)

          increment_total(total_in_batch) do
            klass.constantize.synchronize!(
              synchronization,
              worker_batch,
              years_to_synchronize
            )
          end
        end

        total_in_batch << SpecificStepClassroomsSynchronizer.synchronize!(
          entity.id,
          synchronization.id,
          worker_batch.id
        )

        years_to_synchronize.each do |year|
          increment_total(total_in_batch) do
            ExamRulesSynchronizer.synchronize!(
              synchronization,
              worker_batch,
              [year]
            )
          end

          Unity.with_api_code.each do |unity|
            increment_total(total_in_batch) do
              StudentEnrollmentSynchronizer.synchronize!(
                synchronization,
                worker_batch,
                [year],
                unity.api_code,
                entity.id
              )
            end
          end
        end

        increment_total(total_in_batch) do
          StudentEnrollmentExemptedDisciplinesSynchronizer.synchronize!(
            synchronization,
            worker_batch
          )
        end

        worker_batch.with_lock do
          worker_batch.update(total_workers: total_in_batch.sum)
          worker_batch.end!
          synchronization.mark_as_completed!
        end
      rescue StandardError => error
        synchronization.mark_as_error!('Erro desconhecido.', error.message) if error.class != Sidekiq::Shutdown

        raise error
      end
    end
  end

  def years_to_synchronize
    # TODO voltar a sincronizar todos os anos uma vez por semana (Sábado)
    @years ||= Unity.with_api_code
                    .joins(:school_calendars)
                    .pluck('school_calendars.year').uniq.compact.sort[-2..-1]
  end

  def all_entities
    Entity.all
  end

  def increment_total(total_in_batch, &block)
    total_in_batch << 1

    block.yield
  end
end

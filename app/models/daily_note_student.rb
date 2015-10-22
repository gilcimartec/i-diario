class DailyNoteStudent < ActiveRecord::Base
  acts_as_copy_target

  audited associated_with: :daily_note, except: :daily_note_id

  belongs_to :daily_note
  belongs_to :student

  delegate :avaliation, to: :daily_note

  validates :student,    presence: true
  validates :daily_note, presence: true
  validates :note, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: lambda { |daily_note_student| daily_note_student.maximum_score } }, allow_blank: true

  scope :by_classroom_discipline_student_and_avaliation_test_date_between,
        lambda { |classroom_id, discipline_id, student_id, start_at, end_at| where(
                                                       'daily_notes.classroom_id' => classroom_id,
                                                       'daily_notes.discipline_id' => discipline_id,
                                                       student_id: student_id,
                                                       'avaliations.test_date' => start_at.to_date..end_at.to_date)
                                                          .includes(daily_note: [:avaliation]) }
  scope :by_student_id, lambda { |student_id| where(student_id: student_id) }
  scope :by_discipline_id, lambda { |discipline_id| joins(:daily_note).where(daily_notes: { discipline_id: discipline_id }) }
  scope :by_test_date_between, lambda { |start_at, end_at| by_test_date_between(start_at, end_at) }

  def maximum_score
    return avaliation.test_setting.maximum_score if !avaliation.test_setting.fix_tests
    return avaliation.weight.to_f if avaliation.test_setting_test.allow_break_up
    return avaliation.test_setting_test.weight if !avaliation.test_setting_test.allow_break_up
  end

  private

  def self.by_test_date_between(start_at, end_at)
    joins(
      :daily_note,
      arel_table.join(Avaliation.arel_table, Arel::Nodes::OuterJoin)
        .on(
          Avaliation.arel_table[:id]
            .eq(DailyNote.arel_table[:avaliation_id])
        )
        .join_sources
    )
    .where(avaliations: { test_date: start_at.to_date..end_at.to_date })
  end
end

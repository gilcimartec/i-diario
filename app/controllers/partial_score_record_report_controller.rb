class PartialScoreRecordReportController < ApplicationController
  before_action :require_current_teacher
  before_action :require_current_school_calendar
  before_action :require_current_test_setting

  def form
    @partial_score_record_report_form = PartialScoreRecordReportForm.new
  end

  def report
    @partial_score_record_report_form = PartialScoreRecordReportForm.new(resource_params)

    if @partial_score_record_report_form.valid?
      partial_score_record_report = PartialScoreRecordReport.build(current_entity_configuration,
                                                  current_school_calendar.year,
                                                  @partial_score_record_report_form.step,
                                                  @partial_score_record_report_form.student,
                                                  @partial_score_record_report_form.unity,
                                                  @partial_score_record_report_form.classroom)

      send_data(partial_score_record_report.render, filename: 'registro-de-notas-parciais.pdf', type: 'application/pdf', disposition: 'inline')
    else
      render :form
    end
  end

  private

  def school_calendar_steps
    @school_calendar_steps ||= SchoolCalendarStep.where(school_calendar: current_school_calendar).ordered
  end
  helper_method :school_calendar_steps

  def students
    @students ||= Student.where(id: DailyNoteStudent.by_classroom_id(current_user.current_classroom_id)
                                                    .by_test_date_between(Date.today.beginning_of_year, Date.today.end_of_year)
                                                    .select(:student_id)).ordered
  end
  helper_method :students

  def resource_params
    params.require(:partial_score_record_report_form).permit(:unity_id,
                                                            :classroom_id,
                                                            :student_id,
                                                            :school_calendar_step_id)
  end
end

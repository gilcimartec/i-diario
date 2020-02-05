class Features < EnumerateIt::Base
  associate_values :absence_justification_report,
                   :absence_justifications,
                   :attendance_record_report,
                   :avaliation_exemptions,
                   :avaliation_recovery_diary_records,
                   :avaliations,
                   :can_change_user_password,
                   :change_school_year,
                   :complementary_exam_settings,
                   :complementary_exams,
                   :conceptual_exams,
                   :custom_rounding_tables,
                   :daily_frequencies,
                   :daily_notes,
                   :data_exportations,
                   :descriptive_exams,
                   :discipline_content_records,
                   :discipline_lesson_plan_report,
                   :discipline_lesson_plans,
                   :discipline_teaching_plans,
                   :entity_configurations,
                   :exam_record_report,
                   :final_recovery_diary_records,
                   :ieducar_api_configurations,
                   :ieducar_api_exam_posting_without_restrictions,
                   :ieducar_api_exam_postings,
                   :knowledge_area_content_records,
                   :knowledge_area_lesson_plan_report,
                   :knowledge_area_lesson_plans,
                   :knowledge_area_teaching_plans,
                   :learning_objectives_and_skills,
                   :observation_diary_records,
                   :observation_record_report,
                   :partial_score_record_report,
                   :roles,
                   :school_calendar_events,
                   :school_calendars,
                   :school_term_recovery_diary_records,
                   :teacher_report_cards,
                   :terms_dictionaries,
                   :test_settings,
                   :transfer_notes,
                   :unities,
                   :users,
                   :translations


  sort_by :translation
end

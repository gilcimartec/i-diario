class AddIndexVisibleToStudentEnrollmentClassrooms < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :student_enrollment_classrooms, :visible, algorithm: :concurrently
  end
end

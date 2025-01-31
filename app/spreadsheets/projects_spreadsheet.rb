# frozen_string_literal: true

class ProjectsSpreadsheet < BaseSpreadsheet
  def body(project)
    [
      project.name,
      I18n.t(project.active.to_s),
      translate_date(project.created_at),
      translate_date(project.created_at)
    ]
  end

  def header
    %w[
      name
      active
      created_at
      updated_at
    ].map { |attribute| Project.human_attribute_name(attribute) }
  end
end

class PivotalActivity < ActivityBuilder

  attr_accessor :stories
  attribute :id, Integer
  attribute :version, Integer
  attribute :event_type, String
  attribute :occurred_at, DateTime
  attribute :author, String
  attribute :project_id, Integer
  attribute :description, String
  
  def build
    # double check to make sure a commit with this sha is not already in DB
    @activity = Activity.find_by_reference_3(id.to_s)
    super
  end

  private

  def timestamp
    occurred_at
  end
  
  def activity_params
    story_id = stories[0]["id"] if stories.present?
    current_state = stories[0]["current_state"] if stories.present?
    super.merge({
      :source => "pivotal",
      :action => event_type,
      :description => description,
      :time => occurred_at,
      :reference_1 => story_id,
      :reference_2 => current_state,
      :reference_3 => id.to_s
    })
  end

  def find_project
    if (project_id)
      @project = Project.where(:pivotal_id => project_id).first
    end
  end

  def find_user
    if author
      @user = User.find_by_pivotal_name(author)
    end
    if !user and author
      @user = User.find_by_name(author)
    end
  end

end
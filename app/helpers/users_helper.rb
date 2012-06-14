module UsersHelper
  def show_person_name user
    return "" if user.blank?
    if user.profile &&  user.profile.present?
      user.profile.name
    else
      user.name
    end
  end

  def show_bio user
    if user && user.profile && user.profile.description.present?
      simple_format user.profile.description
    end
  end

end
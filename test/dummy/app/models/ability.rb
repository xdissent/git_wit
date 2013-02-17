class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, Repository, public: true

    if user.has_role? :admin
      can :manage, :all
    else
      can :manage, Repository, user_id: user.id
    end
  end
end

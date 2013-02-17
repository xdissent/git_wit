class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, Repository, public: true

    if user.has_role? :admin
      can :manage, :all
    elsif user.id.present?
      can :manage, Repository, user_id: user.id
      can [:read, :create, :destroy], PublicKey, user_id: user.id
    end
  end
end

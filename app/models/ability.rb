class Ability
  include CanCan::Ability

  def initialize(user)
    user_rules(user)
  end

  def user_rules(user)
    user.roles.each do |role|
      send("#{role}_rules", user) if respond_to?("#{role}_rules")
    end
  end

  def admin_rules(user)
    can :manage, :all
    can :assign_roles, User
    can :edit_profile, User
    can :update_profile, User
    can :report, :all
  end

  def shift_auditor_rules(user)
    can :read, Operator
    can :write, Operator
    can [:edit_profile, :update_profile], User, id: user.id
  end

  def regular_rules(user)
    can :create, :all
    can :update, :all
    # can :destroy, :all
    can :read, :all
    can [:edit_profile, :update_profile], User, id: user.id
    can :report, :all

    cannot :assign_roles, User
  end
end

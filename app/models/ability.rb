class Ability
  include CanCan::Ability

  def initialize(user)
    user_rules(user)
  end

  def user_rules(user)
    user.roles.each do |role|
      send("#{role}_rules") if respond_to?("#{role}_rules")
    end
  end

  def admin_rules
    can :manage, :all
    can :assign_roles, User
    can :edit_profile, User
    can :update_profile, User
    can :report, :all
  end

  def shift_auditor_rules
    can :read, Operator
    can :write, Operator
  end

  def regular_rules
    can :create, :all
    can :update, :all
    can :destroy, :all
    can :read, :all
    can :edit_profile, User
    can :update_profile, User
    can :report, :all

    cannot :assign_roles, User
  end
end

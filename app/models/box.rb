class Box < Account
  before_save :uniq_default_cashbox, if: :multi_use_changed?

  def uniq_default_cashbox
    Box.default_cashbox.update_all(multi_use: :none) if default_cashbox?
  end

  def default_cashbox
    default_cashbox?
  end

  def default_cashbox=(value)
    byebug
    self.multi_use = value ? :default_cashbox : nil
  end
end

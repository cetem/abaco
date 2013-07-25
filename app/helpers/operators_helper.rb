module OperatorsHelper
  def show_shift_duration(obj)
    if obj.start && obj.finish
      hours_in_words ((obj.finish - obj.start) / 3600).round(2)
    end
  end
end

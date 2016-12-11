module OperatorsHelper
  def show_shift_duration(obj)
    distance_of_time_in_words(obj.start, obj.finish) if obj.start && obj.finish
  end

  def worked_time_for_shift(shift)
    shift.finish ? (shift.finish - shift.start) : 0
  end

  def suspicious_shift?(shift)
    worked_time_for_shift(shift) >= 8.hours
  end
end

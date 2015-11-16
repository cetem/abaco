module OperatorsHelper
  def show_shift_duration(obj)
    distance_of_time_in_words(obj.start, obj.finish) if obj.start && obj.finish
  end
end

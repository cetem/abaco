module OutflowsHelper
  
  def kind_selector_for_outflow
    Outflow::KIND.map { |k, v| [t("view.outflows.kind.#{k}"), v] }
  end
  
  def show_outflow_kind(outflow)
    t("view.outflows.kind.#{outflow.kind_symbol}")
  end
end

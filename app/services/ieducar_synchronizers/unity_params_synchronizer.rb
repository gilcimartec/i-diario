class UnityParamsSynchronizer < BaseSynchronizer
  def synchronize!
    update_unity_params(
      HashDecorator.new(
        api.fetch['escolas']
      )
    )
  end

  private

  def api_class
    IeducarApi::UnityParams
  end

  def update_unity_params(unity_params)
    unity_params.each do |unity_param|
      unity_record = unity(unity_param.cod_escola)

      next if unity_record.blank?

      unity_record.tap do |unity|
        unity.uses_differentiated_exam_rule = unity_param.utiliza_regra_diferenciada
        unity.save! if unity.changed?
      end
    end
  end
end

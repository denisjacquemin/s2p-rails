module MessagesHelper

  def build_last_update_meta(status, updated_at)
    if status == 'published'
      return "Publié le #{I18n.l(updated_at.to_datetime().in_time_zone, format: :short)}"
    else
      return "Dernière mise à jour le #{I18n.l(updated_at.to_datetime().in_time_zone, format: :short)}"
    end
  end
end

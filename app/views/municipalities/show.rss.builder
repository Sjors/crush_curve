#encoding: UTF-8
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Positieve getest in #{ @municipality.name }"
    xml.description "Op dagen dat er positieve testuitslagen zijn wordt hier het aantal gegeven."
    xml.link root_url

    @cases.each do |c|
      cache c do
        xml.item do
          xml.title "#{ @municipality.name }: #{ c.new_reports } positief getest"
          xml.description "Er zijn #{ c.new_reports } positieve testuitslagen in #{ @municipality.name } gemeld bij het RIVM in het etmaal voor #{ I18n.l(c.day, format: "%d %B") } 's ochtends. Er kan vertraging zitten in de rapportage."
          xml.pubDate c.created_at.to_s(:rfc822)
          xml.link province_url(@municipality.province)
          xml.guid "crush-curve-case-#{ @municipality.cbs_id }-#{ c.day.to_i }"
        end
      end
    end
  end
end

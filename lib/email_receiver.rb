require 'incoming'
class EmailReceiver < Incoming::Strategies::SendGrid
  def receive(mail)
    puts %(Got message from #{mail.to.first} with subject "#{mail.subject} and the text\n#{mail.body.decoded}")
    mail
  end

  def self.is_otr(text)
    otr_re = /\b(otr)|(off the record)\b/i
    !(text =~ otr_re).nil?
  end

  def self.scrub_fwd(text)
    text.gsub(/^Fwd?: /i, '')
  end

  def self.scrub_space(text)
    text.gsub("%20", " ")
  end

  def self.clean_google_group_footer(text)
    text
      .sub(/\s*--\s*You received this message because you are subscribed to the Google Groups "Transition Pool" group.*/m, "")
      .sub(/\s*--\s*If you would like to subscribe to this group.*/m, "")
  end

  def self.clean_lines(text)
    from_block, body = split_from_chunk(text)
    if body.nil?
      from_block
    else
      [
        from_block,
        clean_single_line_breaks(body)
      ].join('')
    end
  end

  def self.split_from_chunk(text)
    text.partition(/(^From:.*To:.*)\n\n/m).reject { |c| c.empty? }
  end

  def self.clean_single_line_breaks(text)
    text.split(/\n\n+/).map { |line|
      if (line !~ /^--\n/)
        line.sub(/\n{1}/, ' ')
      else
        line
      end
    }.join("\n\n")
  end

  def self.convert(shit)
    split_paragraphs(shit).map { |p|
      convert_line_breaks(p)
    }.map { |p| make_paragraph_object(p) }
      .push(hr)
      .push(footer)
  end

  def self.split_paragraphs(shit)
    shit.split(/\n\n/)
  end

  def self.make_paragraph_object(value)
    {
      type: "Paragraph",
      value: value,
      containers: [

      ]
    }
  end

  def self.convert_line_breaks(shit)
    shit.split(/\n/)
      .map { |line|
      { type: "Text", value: line.strip, styles: [] }
      }.flat_map { |x| [x, {type: "LineBreak"}] }.tap(&:pop)
  end

  def self.hr
    {
      style: "Line",
      containers: [

      ],
      type: "HorizontalRule"
    }
  end

  def self.footer
    {
      containers: [

      ],
      value: [
        {
          styles: [
            "Italic"
          ],
          value: "Public Pool is an automated feed of ",
          type: "Text"
        },
        {
          reference: "http://politburo.kinja.com/here-are-all-the-white-house-pool-reports-1691913651",
          value: [
            {
              styles: [
                "Italic"
              ],
              value: "White House press pool reports",
              type: "Text"
            }
          ],
          type: "Link"
        },
        {
          styles: [
            "Italic"
          ],
          value: ". For live updates, follow ",
          type: "Text"
        },
        {
          reference: "https://twitter.com/whpublicpool",
          value: [
            {
              styles: [
                "Italic"
              ],
              value: "@WHPublicPool",
              type: "Text"
            }
          ],
          type: "Link"
        },
        {
          styles: [
            "Italic"
          ],
          value: " on Twitter.",
          type: "Text"
        }
      ],
      type: "Paragraph"
    }
  end
end

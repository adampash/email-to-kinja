require 'incoming'
class EmailReceiver < Incoming::Strategies::SendGrid
  def receive(mail)
    puts %(Got message from #{mail.to.first} with subject "#{mail.subject} and the text\n#{mail.body.decoded}")
    mail
  end

  def self.scrub_fwd(text)
    text.gsub(/^Fwd?: /i, '')
  end

  def self.scrub_space(text)
    text.gsub("%20", " ")
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
      value: value
    }
  end

  def self.convert_line_breaks(shit)
    shit.split(/\n/)
      .map { |line|
      { type: "Text", value: line.strip }
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

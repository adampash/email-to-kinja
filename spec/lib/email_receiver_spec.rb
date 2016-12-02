require_relative '../../lib/email_receiver'

describe EmailReceiver do
  it "scrubs fwd text from subject" do
    subj = "Fw: This is a thing"
    expect(EmailReceiver.scrub_fwd(subj)).to eq "This is a thing"

    subj = "Fwd: This is a thing"
    expect(EmailReceiver.scrub_fwd(subj)).to eq "This is a thing"

    subj = "FW: This is a thing"
    expect(EmailReceiver.scrub_fwd(subj)).to eq "This is a thing"
  end

  it "converts text to some new kinja bullshit" do
    expect(EmailReceiver.convert(graph_text)).to eq graph_result
  end

  it "splits paragraphs" do
    expect(EmailReceiver.split_paragraphs(graph_text).length)
      .to eq 3
  end

  it "puts those paragraphs into objects" do
    value = "as;dlkjfad"
    result = { type: "Paragraph", value: value, containers: [] }
    expect(EmailReceiver.make_paragraph_object(value))
      .to eq result
  end

  it "creates nodes for line breaks" do
    value = "hello\ngoodbye"
    result = [
      { type: "Text", value: "hello", styles: [] },
      {
        "type": "LineBreak"
      },
      { type: "Text", value: "goodbye", styles: [] },
    ]
    expect(EmailReceiver.convert_line_breaks(value))
      .to eq result
  end


  describe "EmailReceiver.google_group_footer" do
    it "cleans the google group footer" do
      value = "--\
              This is legit email but below we don't want\
              --\
              If you would like to subscribe to this group\
              here is more text blah blah blah"
      result = "--\
              This is legit email but below we don't want"
      expect(EmailReceiver.clean_google_group_footer(value)).to eq result
    end

    it "doesn't do anything if there's no match" do
      value = "--\
              This is legit email but below we should also keep\
              --\
              here is more text blah blah blah"

      expect(EmailReceiver.clean_google_group_footer(value)).to eq value
    end
  end


  def graph_text
    <<-HEREDOC
      Hello.

      It's me!
      How are you?

      I'm angry!
    HEREDOC
  end

  def graph_result
    [
      {
        type: "Paragraph",
        value: [{ type: "Text", value: "Hello.", styles: []}],
        containers: []
      },
      {
        type: "Paragraph",
        containers: [],
        value: [
          { type: "Text", value: "It's me!", styles: [] },
          { type: "LineBreak" },
          { type: "Text", value: "How are you?", styles: [] }
        ]
      },
      {
        type: "Paragraph",
        containers: [],
        value: [{ type: "Text", value: "I'm angry!", styles: [] }]
      },
    ].push(EmailReceiver.hr).push(EmailReceiver.footer)
  end
end

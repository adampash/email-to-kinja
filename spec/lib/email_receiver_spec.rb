require_relative '../../lib/email_receiver'

describe EmailReceiver do
  it "checks for otr or off the record" do
    text = "This is off the record"
    t1 = "this is otr"
    t2 = "this is fine"
    t3 = "OTR report"
    t4 = "OFF THE RECORD report"
    t5 = "wotrix"

    expect(EmailReceiver.is_otr(text)).to be true
    expect(EmailReceiver.is_otr(t1)).to be true
    expect(EmailReceiver.is_otr(t2)).to be false
    expect(EmailReceiver.is_otr(t3)).to be true
    expect(EmailReceiver.is_otr(t4)).to be true
    expect(EmailReceiver.is_otr(t5)).to be false
  end

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
      value = "--\n\
              This is legit email but below we don't want\n\
              --\n\
              You received this message because you are subscribed to the Google Groups \"Transition Pool\" group\n\
              here is more text blah blah blah"
      result = "--\n\
              This is legit email but below we don't want"
      expect(EmailReceiver.clean_google_group_footer(value)).to eq result
    end

    it "cleans this other google group footer" do
      value = "--\n\
              This is legit email but below we don't want\
              --\nIf you would like to subscribe to this group, please fill out the form here: https://docs.google.com/forms/d/e/1FAIpQLSf0ltDTLI7xxIdh4N4iZJY2tPPuJdoag3WJ8qy8ktrLnJxE9Q/viewform

      You may view the pool rotation here"
      result = "--\n\
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

  describe "EmailReceiver.clean_single_line_breaks" do
    it "removes single line breaks but keeps double" do
      value = "This should\nall be on one line\n\n\nBut this should be two lines below that,\nmake sense?"

      result = "This should all be on one line\n\nBut this should be two lines below that, make sense?"

      expect(EmailReceiver.clean_single_line_breaks(value)).to eq result
    end

    it "keeps the single break if preceeded by --" do
      value = "This should all be on one line\n\n--\nBut the -- should stay where it is"

      expect(EmailReceiver.clean_single_line_breaks(value)).to eq value
    end

    it "doesn't do anyting if there are no line breaks" do
      value = "HI THERE"

      expect(EmailReceiver.clean_single_line_breaks(value)).to eq value
    end
  end

  describe "EmailReciever.split_from_chunk" do
    it "splits the from chunk from the rest of the text if it exists" do
      email = "From: Lucía Leal <xxx@efeamerica.com>\n\
Sent: Thursday, December 1, 2016 20:13\n\
To: Goodman, Meghan Hays K. EOP/OVP\n\
Subject: VP pool report #3\n\
\n\
Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30.\n\
He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      result = [
        "From: Lucía Leal <xxx@efeamerica.com>\n\
Sent: Thursday, December 1, 2016 20:13\n\
To: Goodman, Meghan Hays K. EOP/OVP\n\
Subject: VP pool report #3\n\n",
"Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30.\n\
He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      ]
      expect(EmailReceiver.split_from_chunk(email)).to eq result
    end

    it "only happens on the from chunk" do
      email = "Sent: Thursday, December 1, 2016 20:13\
To: Goodman, Meghan Hays K. EOP/OVP\
Subject: VP pool report #3\
\
Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30.\
He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      expect(EmailReceiver.split_from_chunk(email)).to eq [email]
    end
  end

  describe "EmailReciever.clean_lines" do
    it "splits the from chunk, cleans the body, and puts them back together" do
      email = "From: Lucía Leal <xxx@efeamerica.com>\n\
Sent: Thursday, December 1, 2016 20:13\n\
To: Goodman, Meghan Hays K. EOP/OVP\n\
Subject: VP pool report #3\n\
\n\
Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30.\n\
He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      result = "From: Lucía Leal <xxx@efeamerica.com>\n\
Sent: Thursday, December 1, 2016 20:13\n\
To: Goodman, Meghan Hays K. EOP/OVP\n\
Subject: VP pool report #3\n\
\n\
Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30. He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      expect(EmailReceiver.clean_lines(email)).to eq result
    end
    it "doesn't do anything if there's nothing to be done" do
      email = "Wow what an email"

      expect(EmailReceiver.clean_lines(email)).to eq email
    end
  end

  describe "EmailReciever.split_from_chunk" do
    it "splits the from chunk from the rest of the text if it exists" do
      email = "From: Lucía Leal <xxx@efeamerica.com>\
Sent: Thursday, December 1, 2016 20:13\
To: Goodman, Meghan Hays K. EOP/OVP\
Subject: VP pool report #3\
\
Vice President Biden arrived at Casa de Huespedes Ilustres at around 19:30.
He was greeted by President Santos, dressed with beige pants and a white shirt with a pin of a white dove."

      result = email.split(/\n\n/)

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

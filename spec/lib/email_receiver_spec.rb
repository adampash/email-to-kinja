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
end

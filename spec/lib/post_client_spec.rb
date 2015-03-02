require_relative '../../lib/post_client'

describe PostClient do
  it 'does not trim short sentences' do
    sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars."
    excerpt = PostClient.shrink(sentence)
    expect(excerpt).to eq sentence
  end

  it 'trims long pieces of text to fp excerpts' do
    long_sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars. It's a tale of celebrity aspiration and Hollywood misery that weaves together incest, mental illness, a dead kid or two, a burn victim (played by Mia Wasikowska), a washed-up actress gunning for another hit who resembles what Lindsay Lohan might be like in 15 years (Julianne Moore as Havana Segrand), and a Bieber-esque child star who's already been to rehab (Evan Bird as Benjie Weiss). It's full of desperation, violence, and excruciatingly grim humor. There are images in this movie that are as indelible as they are hard to look at."
    excerpt = PostClient.shrink(long_sentence)
    expect(excerpt.length).to be < 300
    expect(excerpt[-3..-1]).to eq '...'
  end

  it 'does not use an ellipsis if last word ends with . or ! or ?' do
    long_sentence = "He's responsible for the likes of 1983's Videodrome, 1986's The Fly remake, 1988's Dead Ringers, and 2005's A History of Violence, but David Cronenberg may have delivered his most disturbing movie with Maps to the Stars. It's a tale of celebrity aspiration and Hollywood misery! That weaves together incest, mental illness, a dead kid or two, a burn victim (played by Mia Wasikowska), a washed-up actress gunning for another hit who resembles what Lindsay Lohan might be like in 15 years (Julianne Moore as Havana Segrand), and a Bieber-esque child star who's already been to rehab (Evan Bird as Benjie Weiss). It's full of desperation, violence, and excruciatingly grim humor. There are images in this movie that are as indelible as they are hard to look at."
    excerpt = PostClient.shrink(long_sentence)
    expect(excerpt[-3..-1]).to_not eq '...'
  end
end

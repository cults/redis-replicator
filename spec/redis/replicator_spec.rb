# frozen_string_literal: true

RSpec.describe Redis::Replicator do
  let(:replicator) { described_class.new(urls:) }
  let(:urls) do
    [
      "redis://localhost:7777/0",
      "redis://localhost:8888/0",
    ]
  end

  it "has a version number" do
    expect(Redis::Replicator::VERSION).not_to be nil
  end

  it "can be instanciated" do
    expect(replicator.get("ok")).to be_nil
  end
end

# frozen_string_literal: true

RSpec.describe Redis::Replicator do
  it "has a version number" do
    expect(Redis::Replicator::VERSION).not_to be nil
  end

  context "with mocked instances" do
    let(:replicator) { described_class.new(urls:) }
    let(:urls) { ["redis://localhost:7777/0", "redis://localhost:8888/0"] }
    let(:redis1) { instance_double Redis }
    let(:redis2) { instance_double Redis }

    before do
      allow(Redis)
        .to receive(:new)
        .with(url: "redis://localhost:7777/0")
        .and_return(redis1)
      allow(Redis)
        .to receive(:new)
        .with(url: "redis://localhost:8888/0")
        .and_return(redis2)
    end

    where(:method, :args, :return1, :return2, :expected_result) do
      [
        [:exists?, ["key"], true, true, true],
        [:exists?, ["key"], true, false, true],
        [:exists?, ["key"], false, true, true],
        [:exists?, ["key"], false, false, false],
        [:exists?, ["key"], Errno::ECONNREFUSED, false, false],
        [:exists?, ["key"], false, Errno::ECONNREFUSED, false],
        [:exists?, ["key"], Errno::ECONNREFUSED, Errno::ECONNREFUSED, false],
        [:get, ["key"], "ok", nil, "ok"],
        [:get, ["key"], "ok", Errno::ECONNREFUSED, "ok"],
        [:get, ["key"], "ok", "ko", "ok"],
        [:get, ["key"], nil, "ok", "ok"],
        [:get, ["key"], Errno::ECONNREFUSED, "ok", "ok"],
        [:get, ["key"], nil, nil, nil],
        [:get, ["key"], Errno::ECONNREFUSED, nil, nil],
        [:get, ["key"], Errno::ECONNREFUSED, Errno::ECONNREFUSED, nil],
        [:get, ["key"], nil, Errno::ECONNREFUSED, nil],
        [:set, ["key", 1], nil, nil, nil],
        [:set, ["key", 1], Errno::ECONNREFUSED, nil, nil],
        [:set, ["key", 1], nil, Errno::ECONNREFUSED, nil],
        [:setex, ["key", 60, 1], nil, nil, nil],
        [:setex, ["key", 60, 1], nil, Errno::ECONNREFUSED, nil],
        [:setex, ["key", 60, 1], Errno::ECONNREFUSED, nil, nil],
        [:setex, ["key", 60, 1], Errno::ECONNREFUSED, nil, nil],
        [:del, ["key"], nil, nil, nil],
        [:del, ["key"], nil, Errno::ECONNREFUSED, nil],
        [:del, ["key"], Errno::ECONNREFUSED, nil, nil],
      ]
    end

    before do
      if return1.is_a?(Class)
        allow(redis1).to receive(method).with(*args).and_raise(return1)
      else
        allow(redis1).to receive(method).with(*args).and_return(return1)
      end

      if return2.is_a?(Class)
        allow(redis2).to receive(method).with(*args).and_raise(return2)
      else
        allow(redis2).to receive(method).with(*args).and_return(return2)
      end
    end

    with_them do
      it do
        expect(replicator.public_send(method, *args)).to be(expected_result)

        if return1.is_a?(Class) || return1.nil?
          expect(redis2).to have_received(method).with(*args)
        end

        expect(redis1).to have_received(method).with(*args)
      end
    end
  end
end

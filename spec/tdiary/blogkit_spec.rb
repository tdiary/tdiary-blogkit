require 'spec_helper'

describe TDiary::Blogkit do
  it 'has a version number' do
    expect(TDiary::Blogkit::VERSION).not_to be nil
  end

  it 'enables blog style' do
    expect(TDiary::Style::BlogDiary).not_to be nil
    expect(TDiary::Style::BlogrdDiary).not_to be nil
    expect(TDiary::Style::BlogwikiDiary).not_to be nil
  end

  it 'enables blogkit extensions' do
    expect(TDiary::Extensions::Blogkit).not_to be nil
  end
end

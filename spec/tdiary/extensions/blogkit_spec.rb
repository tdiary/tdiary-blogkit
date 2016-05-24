require 'spec_helper'

describe TDiary::Extensions::Blogkit do
  describe "#sp_path" do
    it 'returns the plugin path' do
      expect(TDiary::Extensions::Blogkit.sp_path).to end_with('/plugin')
    end

    it 'returns the javascript path' do
      expect(TDiary::Extensions::Blogkit.assets_path).to end_with('/js')
    end
  end
end

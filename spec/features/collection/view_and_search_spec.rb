
# frozen_string_literal: true
require 'feature_spec_helper'

include Selectors::Dashboard

describe Collection, type: :feature do
  let!(:collection)  { create(:public_collection, creator: ["somebody"], depositor: current_user.login, members: [file1, file2]) }

  let(:current_user) { create(:user) }
  let(:file1)        { create(:public_file, title: ["world.png"], depositor: current_user.login) }
  let(:file2)        { create(:private_file, title: ["little_file.txt"], depositor: current_user.login) }

  context 'with a logged in user' do
    before do
      sign_in_with_js(current_user)
      visit '/dashboard/collections'
      db_item_title(collection).click
    end

    describe 'viewing a collection and its files' do
      specify do
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first
        expect(page).to have_content collection.creator.first
        expect(page).to have_content file1.title.first
        expect(page).to have_content file2.title.first
        expect(page).to have_content "Total Items 2"
        expect(page).to have_content "Size 0 Bytes"
        go_to_dashboard_works

        # TODO: Re-add this test once ticket https://github.com/psu-stewardship/scholarsphere/issues/294
        # has been completed. Or totally remove the commented test if the ticket is closed.
        # expect(page).to have_content "Is part of: #{collection.title}"

        expect(page).to have_link("My Works")
        expect(page).to have_link("My Collections")
      end
    end

    describe 'searching within a collection' do
      specify do
        fill_in 'collection_search', with: file1.title.first
        click_button 'collection_submit'
        expect(page).to have_content collection.title.first
        expect(page).to have_content collection.description.first

        # Should have search results / contents listing
        expect(page).to have_content file1.title.first
        expect(page).not_to have_content file2.title.first

        # Should not have Collection Descriptive metadata table
        expect(page).not_to have_content collection.creator.first
      end
    end
  end

  context 'with a public user' do
    it "displays the collection and only public files" do
      visit "/collections/#{collection.id}"
      expect(page.status_code).to eql(200)
      expect(page).to have_content collection.title.first
      expect(page).to have_content file1.title.first
      expect(page).not_to have_content file2.title.first
    end
  end
end

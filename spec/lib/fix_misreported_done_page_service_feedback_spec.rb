require 'fix_misreported_done_page_service_feedback'
require 'rails_helper'

RSpec.describe FixMisreportedDonePageServiceFeedback do
  let(:start_date) { Date.new(2014, 6, 10) }
  let(:inbetween_date) { start_date + 5 }
  let(:end_date) { start_date + 10 }
  let(:test_logger) { Rails.logger }

  subject { described_class.new(start_date, end_date, test_logger) }

  describe '#fix!' do
    let(:service_slug) { 'register-to-vote' }
    context 'for ServiceFeedback instances' do
      context 'with "/done"-less version of supplied path' do
        context 'created before the start date' do
          let!(:service_feedback) do
            FactoryGirl.create(
              :service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: start_date - 10,
            )
          end

          it 'does not have its path changed' do
            subject.fix!(service_slug)
            expect(service_feedback.reload.path).not_to eq "/done/#{service_slug}"
          end
        end

        context 'created after the end date' do
          let!(:service_feedback) do
            FactoryGirl.create(
              :service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: end_date + 10,
            )
          end

          it 'does not have its path changed' do
            subject.fix!(service_slug)
            expect(service_feedback.reload.path).not_to eq "/done/#{service_slug}"
          end
        end

        context 'created between the start and end dates' do
          let!(:service_feedback) do
            FactoryGirl.create(
              :service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: inbetween_date,
            )
          end

          it 'has its path changed to the /done version' do
            subject.fix!(service_slug)
            expect(service_feedback.reload.path).to eq "/done/#{service_slug}"
          end
        end
      end

      it 'ignores those having paths with suffixes of the supplied service' do
        service_feedback = FactoryGirl.create(
          :service_feedback,
          service_satisfaction_rating: 1,
          slug: 'register-to-vote-abroad',
          path: "/register-to-vote-abroad",
          created_at: inbetween_date,
        )

        subject.fix!('register-to-vote')
        expect(service_feedback.reload.path).not_to eq "/done/register-to-vote"
      end
    end

    context 'for AggregatedServiceFeedback instances' do
      context 'with "/done"-less version of supplied path' do
        context 'created before the start date' do
          let!(:aggregated_service_feedback) do
            FactoryGirl.create(
              :aggregated_service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: start_date - 10,
            )
          end

          it 'does not have its path changed' do
            subject.fix!(service_slug)
            expect(aggregated_service_feedback.reload.path).not_to eq "/done/#{service_slug}"
          end
        end

        context 'created after the end date' do
          let!(:aggregated_service_feedback) do
            FactoryGirl.create(
              :aggregated_service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: end_date + 10,
            )
          end

          it 'does not have its path changed' do
            subject.fix!(service_slug)
            expect(aggregated_service_feedback.reload.path).not_to eq "/done/#{service_slug}"
          end
        end

        context 'created between the start and end dates' do
          let!(:aggregated_service_feedback) do
            FactoryGirl.create(
              :aggregated_service_feedback,
              service_satisfaction_rating: 1,
              slug: service_slug,
              path: "/#{service_slug}",
              created_at: inbetween_date,
            )
          end

          it 'has its path changed to the /done version' do
            subject.fix!(service_slug)
            expect(aggregated_service_feedback.reload.path).to eq "/done/#{service_slug}"
          end
        end
      end

      it 'ignores those having paths with suffixes of the supplied service' do
        aggregated_service_feedback = FactoryGirl.create(
          :aggregated_service_feedback,
          service_satisfaction_rating: 1,
          slug: 'register-to-vote-abroad',
          path: "/register-to-vote-abroad",
          created_at: inbetween_date,
        )

        subject.fix!('register-to-vote')
        expect(aggregated_service_feedback.reload.path).not_to eq "/done/register-to-vote"
      end
    end
  end

  describe '#fix_all!' do
    let!(:done_page_1) { FactoryGirl.create(:service_feedback, path: '/done/service-1') }
    let!(:done_page_2) { FactoryGirl.create(:service_feedback, path: '/done/service-2') }
    let!(:done_page_3) { FactoryGirl.create(:long_form_contact, path: '/done/service-3', details: 'Hi there') }
    let!(:misreported_feedback_for_done_page_1) { FactoryGirl.create(:service_feedback, slug: 'service-1', path: '/service-1', created_at: inbetween_date) }
    let!(:misreported_feedback_for_done_page_2) { FactoryGirl.create(:service_feedback, slug: 'service-2', path: '/service-2', created_at: inbetween_date) }
    let!(:misreported_feedback_for_done_page_3) { FactoryGirl.create(:service_feedback, slug: 'service-3', path: '/service-3', created_at: inbetween_date) }

    it 'fixes misreported feedback for all /done pages that have service feedback' do
      subject.fix_all!
      expect(misreported_feedback_for_done_page_1.reload.path).to eq '/done/service-1'
      expect(misreported_feedback_for_done_page_2.reload.path).to eq '/done/service-2'
    end

    it 'ignores misreported feedback for a /done page that has no service feedback' do
      subject.fix_all!
      expect(misreported_feedback_for_done_page_3.reload.path).not_to eq '/done/service-3'
    end
  end
end

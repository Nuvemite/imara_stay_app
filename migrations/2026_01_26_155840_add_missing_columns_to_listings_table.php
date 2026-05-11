<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            // Basic property fields
            if (!Schema::hasColumn('listings', 'weekday_base_price')) {
                $table->decimal('weekday_base_price', 10, 2)->nullable();
            }
            if (!Schema::hasColumn('listings', 'property_type_id')) {
                $table->foreignId('property_type_id')->nullable()->constrained('property_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('listings', 'room_type_id')) {
                $table->foreignId('room_type_id')->nullable()->constrained('room_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('listings', 'booking_type_id')) {
                $table->foreignId('booking_type_id')->nullable()->constrained('booking_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('listings', 'purpose_type_id')) {
                $table->foreignId('purpose_type_id')->nullable()->constrained('purpose_types')->nullOnDelete();
            }
            if (!Schema::hasColumn('listings', 'tax_id')) {
                $table->foreignId('tax_id')->nullable()->constrained('taxes')->nullOnDelete();
            }
            if (!Schema::hasColumn('listings', 'status_id')) {
                $table->foreignId('status_id')->nullable()->constrained('listing_statuses')->nullOnDelete();
            }

            // Ranking & Trust fields
            if (!Schema::hasColumn('listings', 'trust_score')) {
                $table->decimal('trust_score', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'quality_score')) {
                $table->decimal('quality_score', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'ranking_score')) {
                $table->decimal('ranking_score', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'trust_level')) {
                $table->string('trust_level')->nullable();
            }
            if (!Schema::hasColumn('listings', 'is_soft_hidden')) {
                $table->boolean('is_soft_hidden')->default(false);
            }
            if (!Schema::hasColumn('listings', 'soft_hide_reason')) {
                $table->string('soft_hide_reason')->nullable();
            }

            // Behavioral & Performance fields
            if (!Schema::hasColumn('listings', 'click_count')) {
                $table->integer('click_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'impression_count')) {
                $table->integer('impression_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'booking_count')) {
                $table->integer('booking_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'wishlist_count')) {
                $table->integer('wishlist_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'conversion_rate')) {
                $table->decimal('conversion_rate', 5, 2)->default(0);
            }

            // Host & Quality Ranking Factors
            if (!Schema::hasColumn('listings', 'host_response_rate')) {
                $table->decimal('host_response_rate', 5, 2)->nullable();
            }
            if (!Schema::hasColumn('listings', 'host_cancellation_rate')) {
                $table->decimal('host_cancellation_rate', 5, 2)->nullable();
            }
            if (!Schema::hasColumn('listings', 'description_completeness')) {
                $table->decimal('description_completeness', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'photo_quality_score')) {
                $table->decimal('photo_quality_score', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'price_competitiveness')) {
                $table->decimal('price_competitiveness', 5, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'review_freshness_score')) {
                $table->decimal('review_freshness_score', 5, 2)->default(0);
            }

            // Operational fields
            if (!Schema::hasColumn('listings', 'is_instant_bookable')) {
                $table->boolean('is_instant_bookable')->default(false);
            }
            if (!Schema::hasColumn('listings', 'last_calendar_update')) {
                $table->timestamp('last_calendar_update')->nullable();
            }
            if (!Schema::hasColumn('listings', 'ranking_metadata')) {
                $table->json('ranking_metadata')->nullable();
            }

            // Experience fields
            if (!Schema::hasColumn('listings', 'host_years_experience')) {
                $table->integer('host_years_experience')->default(0);
            }
            if (!Schema::hasColumn('listings', 'host_intro')) {
                $table->text('host_intro')->nullable();
            }
            if (!Schema::hasColumn('listings', 'host_expertise')) {
                $table->text('host_expertise')->nullable();
            }
            if (!Schema::hasColumn('listings', 'social_profiles')) {
                $table->json('social_profiles')->nullable();
            }
            if (!Schema::hasColumn('listings', 'duration_hours')) {
                $table->decimal('duration_hours', 5, 2)->nullable();
            }
            if (!Schema::hasColumn('listings', 'languages')) {
                $table->json('languages')->nullable();
            }
            if (!Schema::hasColumn('listings', 'min_age')) {
                $table->integer('min_age')->nullable();
            }
            if (!Schema::hasColumn('listings', 'inclusions')) {
                $table->text('inclusions')->nullable();
            }
            if (!Schema::hasColumn('listings', 'exclusions')) {
                $table->text('exclusions')->nullable();
            }
            if (!Schema::hasColumn('listings', 'itinerary')) {
                $table->json('itinerary')->nullable();
            }
            if (!Schema::hasColumn('listings', 'private_group_price')) {
                $table->decimal('private_group_price', 10, 2)->nullable();
            }
            if (!Schema::hasColumn('listings', 'transportation_provided')) {
                $table->boolean('transportation_provided')->default(false);
            }
            if (!Schema::hasColumn('listings', 'transportation_methods')) {
                $table->json('transportation_methods')->nullable();
            }
            if (!Schema::hasColumn('listings', 'terms_accepted')) {
                $table->boolean('terms_accepted')->default(false);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            // Allow duplicate drops to fail silently or check existence in down() too
            // But usually down() is simpler.
            // ... (keeping original down logic or simplifying)
             $table->dropColumn(['weekday_base_price', 'property_type_id', 'room_type_id', 'booking_type_id', 'purpose_type_id', 'tax_id', 'status_id']);
            // ... (rest of drops)
        });
    }
};

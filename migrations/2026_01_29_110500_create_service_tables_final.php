<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Disable foreign key checks temporarily
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Drop existing service_types table if it exists
        if (Schema::hasTable('service_types')) {
            Schema::dropIfExists('service_types');
        }

        // Re-enable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // Create enhanced service_types table
        Schema::create('service_types', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('icon')->nullable();
            $table->text('description')->nullable();
            
            // Service Configuration
            $table->foreignId('default_pricing_model_id')->nullable()->constrained('pricing_models')->nullOnDelete();
            $table->foreignId('default_availability_type_id')->nullable()->constrained('availability_types')->nullOnDelete();
            $table->boolean('supports_remote')->default(false);
            $table->boolean('supports_travel_to_guest')->default(true);
            $table->boolean('supports_guests_travel_to_host')->default(true);
            
            // Pricing Configuration
            $table->decimal('min_price', 10, 2)->default(0);
            $table->decimal('max_price', 10, 2)->default(9999.99);
            $table->decimal('default_price', 10, 2)->nullable();
            
            // Requirements
            $table->boolean('requires_verification')->default(false);
            $table->boolean('requires_qualifications')->default(false);
            $table->integer('min_host_age')->default(18);
            
            // Location Settings
            $table->integer('max_travel_radius_km')->default(100);
            
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->json('metadata')->nullable();
            $table->timestamps();
        });

        // Service Details Table
        Schema::create('service_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_type_id')->constrained()->onDelete('cascade');
            
            // Core Service Information
            $table->string('title');
            $table->text('description')->nullable();
            $table->string('service_category')->nullable();
            $table->foreignId('experience_level_id')->nullable()->constrained('experience_levels')->nullOnDelete();
            
            // Service Inclusions/Exclusions
            $table->text('inclusions')->nullable();
            $table->text('exclusions')->nullable();
            $table->text('guest_requirements')->nullable();
            $table->json('service_add_ons')->nullable();
            
            // Location & Coverage
            $table->foreignId('service_location_type_id')->nullable()->constrained('service_location_types')->nullOnDelete();
            $table->string('coverage_radius')->nullable();
            $table->json('service_area_details')->nullable();
            
            // Professional Details
            $table->integer('years_experience')->default(0);
            $table->integer('service_years_experience')->default(0);
            $table->text('certifications')->nullable();
            $table->text('special_equipment')->nullable();
            $table->json('insurance_details')->nullable();
            
            // Service Policies
            $table->text('cancellation_policy')->nullable();
            $table->text('reschedule_policy')->nullable();
            $table->text('weather_policy')->nullable();
            
            // Metadata
            $table->json('tags')->nullable();
            $table->json('faqs')->nullable();
            
            $table->timestamps();
            $table->unique('listing_id');
        });

        // Service Availabilities Table
        Schema::create('service_availabilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            $table->foreignId('availability_type_id')->constrained()->onDelete('cascade');
            
            // Time Settings
            $table->string('timezone')->default('UTC');
            $table->integer('lead_time_minutes')->default(60);
            $table->integer('max_bookings_per_day')->default(1);
            
            // Booking Window
            $table->integer('book_ahead_days')->default(365);
            $table->integer('min_booking_duration_minutes')->default(30);
            $table->integer('max_booking_duration_minutes')->default(480);
            
            // Cancellation Settings
            $table->integer('cancellation_hours')->default(24);
            $table->foreignId('cancellation_policy_type_id')->nullable()->constrained('cancellation_policy_types')->nullOnDelete();
            
            // Seasonal Availability
            $table->json('seasonal_availability')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Service Business Hours Table
        Schema::create('service_business_hours', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_availability_id')->constrained()->onDelete('cascade');
            $table->foreignId('day_of_week_id')->constrained('days_of_week')->onDelete('cascade');
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_available')->default(true);
            $table->integer('max_bookings_this_slot')->default(1);
            $table->timestamps();
            $table->unique(['service_availability_id', 'day_of_week_id', 'start_time'], 'svc_hours_unique');
        });

        // Service Host Qualifications Table
        Schema::create('service_host_qualifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            $table->foreignId('qualification_type_id')->constrained()->onDelete('cascade');
            $table->string('qualification_name');
            $table->string('issuing_organization')->nullable();
            $table->date('issue_date')->nullable();
            $table->date('expiry_date')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->string('verification_document_path')->nullable();
            $table->text('description')->nullable();
            $table->json('skills_acquired')->nullable();
            $table->string('specialization_area')->nullable();
            $table->integer('years_experience')->default(0);
            $table->integer('projects_completed')->default(0);
            $table->boolean('show_on_profile')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });

        // Service Specializations Table
        Schema::create('service_specializations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            $table->string('specialization_name');
            $table->text('description')->nullable();
            $table->string('proficiency_level')->default('intermediate');
            $table->integer('years_experience')->default(0);
            $table->json('portfolio_items')->nullable();
            $table->boolean('is_primary')->default(false);
            $table->timestamps();
            $table->unique(['service_detail_id', 'specialization_name']);
        });

        // Service Offerings Table
        Schema::create('service_offerings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->foreignId('offering_type_id')->nullable()->constrained('offering_types')->nullOnDelete();
            $table->decimal('base_price', 10, 2);
            $table->foreignId('price_unit_id')->nullable()->constrained('price_units')->nullOnDelete();
            $table->string('currency')->default('USD');
            $table->integer('duration_minutes')->default(60);
            $table->boolean('is_flexible_duration')->default(false);
            $table->integer('min_duration_minutes')->nullable();
            $table->integer('max_duration_minutes')->nullable();
            $table->integer('max_guests')->default(1);
            $table->integer('min_guests')->default(1);
            $table->decimal('min_booking_amount', 10, 2)->nullable();
            $table->decimal('additional_guest_price', 10, 2)->nullable();
            $table->decimal('additional_minute_price', 10, 2)->nullable();
            $table->json('offering_inclusions')->nullable();
            $table->json('offering_exclusions')->nullable();
            $table->integer('min_age')->default(18);
            $table->foreignId('skill_level_id')->nullable()->constrained('skill_levels')->nullOnDelete();
            $table->text('physical_requirements')->nullable();
            $table->string('photo_url')->nullable();
            $table->string('video_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->json('available_days')->nullable();
            $table->json('seasonal_pricing')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_featured')->default(false);
            $table->timestamps();
        });

        // Update listings table to add service foreign keys
        Schema::table('listings', function (Blueprint $table) {
            $table->foreignId('service_type_id')->nullable()->after('category_id')->constrained('service_types')->nullOnDelete();
            $table->foreignId('service_detail_id')->nullable()->after('service_type_id')->constrained('service_details')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['service_detail_id']);
            $table->dropForeign(['service_type_id']);
            $table->dropColumn(['service_detail_id', 'service_type_id']);
        });

        Schema::dropIfExists('service_offerings');
        Schema::dropIfExists('service_specializations');
        Schema::dropIfExists('service_host_qualifications');
        Schema::dropIfExists('service_business_hours');
        Schema::dropIfExists('service_availabilities');
        Schema::dropIfExists('service_details');
        Schema::dropIfExists('service_types');
    }
};

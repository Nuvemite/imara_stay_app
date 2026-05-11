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
        // First, let's check what exists and handle dependencies properly
        $this->handleExistingDependencies();

        // Create all the new tables in the correct order
        $this->createServiceTypesTable();
        $this->createServiceDetailsTable();
        $this->createServiceAvailabilityTables();
        $this->createServiceQualificationTables();
        $this->createServiceOfferingsTable();
        $this->createServiceFinalDetailsTables();
        $this->updateListingsTable();
    }

    /**
     * Handle existing dependencies
     */
    private function handleExistingDependencies(): void
    {
        // Drop foreign key from service_subcategories if it exists
        if (Schema::hasTable('service_subcategories')) {
            Schema::table('service_subcategories', function (Blueprint $table) {
                $sm = Schema::getConnection()->getDoctrineSchemaManager();
                $foreignKeys = $sm->listTableForeignKeys('service_subcategories');
                
                foreach ($foreignKeys as $foreignKey) {
                    if ($foreignKey->getColumns() === ['service_type_id']) {
                        $table->dropForeign($foreignKey->getName());
                        break;
                    }
                }
            });
        }

        // Drop conflicting tables if they exist to ensure clean state
        Schema::disableForeignKeyConstraints();
        Schema::dropIfExists('service_transportation_methods');
        Schema::dropIfExists('service_final_details');
        Schema::dropIfExists('service_offerings');
        Schema::dropIfExists('service_specializations');
        Schema::dropIfExists('service_host_qualifications');
        Schema::dropIfExists('service_business_hours');
        Schema::dropIfExists('service_availabilities');
        Schema::dropIfExists('service_details');
        Schema::dropIfExists('service_types');
        Schema::enableForeignKeyConstraints();
    }

    /**
     * Create enhanced service_types table
     */
    private function createServiceTypesTable(): void
    {
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

        // Recreate foreign key for service_subcategories
        if (Schema::hasTable('service_subcategories')) {
            Schema::table('service_subcategories', function (Blueprint $table) {
                $table->foreign('service_type_id')->constrained('service_types')->onDelete('cascade');
            });
        }
    }

    /**
     * Create service details table
     */
    private function createServiceDetailsTable(): void
    {
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
    }

    /**
     * Create service availability tables
     */
    private function createServiceAvailabilityTables(): void
    {
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
    }

    /**
     * Create service qualification tables
     */
    private function createServiceQualificationTables(): void
    {
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
    }

    /**
     * Create service offerings table
     */
    private function createServiceOfferingsTable(): void
    {
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
    }

    /**
     * Create service final details tables
     */
    private function createServiceFinalDetailsTables(): void
    {
        Schema::create('service_final_details', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            
            // Transportation
            $table->boolean('provides_transportation')->default(false);
            $table->text('transportation_notes')->nullable();
            
            // Terms and Policies
            $table->boolean('terms_accepted')->default(false);
            $table->timestamp('terms_accepted_at')->nullable();
            $table->string('terms_ip_address', 45)->nullable();
            $table->foreignId('cancellation_policy_id')->nullable()->constrained('cancellation_policy_types')->nullOnDelete();
            $table->boolean('host_cancellation_policy_accepted')->default(false);
            $table->boolean('privacy_policy_accepted')->default(false);
            
            // Quality and Standards
            $table->boolean('quality_standards_accepted')->default(false);
            $table->boolean('quality_check_consent')->default(false);
            
            // Additional Requirements
            $table->text('special_requirements')->nullable();
            $table->text('accessibility_notes')->nullable();
            $table->text('safety_measures')->nullable();
            
            // Legal and Compliance
            $table->boolean('legal_disclaimer_accepted')->default(false);
            $table->boolean('age_verification')->default(false);
            $table->boolean('insurance_confirmation')->default(false);
            
            // Metadata
            $table->integer('completion_percentage')->default(0);
            $table->integer('last_step_completed')->nullable();
            $table->boolean('is_ready_to_publish')->default(false);
            
            $table->timestamps();
            $table->unique('service_detail_id');
        });

        Schema::create('service_transportation_methods', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_final_detail_id')->constrained()->onDelete('cascade');
            $table->foreignId('transportation_method_id')->constrained()->onDelete('cascade');
            $table->json('vehicle_details')->nullable();
            $table->integer('capacity')->nullable();
            $table->json('insurance_info')->nullable();
            $table->json('driver_license_info')->nullable();
            $table->timestamps();
            $table->unique(['service_final_detail_id', 'transportation_method_id'], 'svc_transport_unique');
        });
    }

    /**
     * Update listings table
     */
    private function updateListingsTable(): void
    {
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

        Schema::dropIfExists('service_transportation_methods');
        Schema::dropIfExists('service_final_details');
        Schema::dropIfExists('service_offerings');
        Schema::dropIfExists('service_specializations');
        Schema::dropIfExists('service_host_qualifications');
        Schema::dropIfExists('service_business_hours');
        Schema::dropIfExists('service_availabilities');
        Schema::dropIfExists('service_details');
        Schema::dropIfExists('service_types');
    }
};

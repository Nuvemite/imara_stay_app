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
        // Service Final Details Table
        if (!Schema::hasTable('service_final_details')) {
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
        }

        // Service Transportation Methods Pivot Table
        if (!Schema::hasTable('service_transportation_methods')) {
            Schema::create('service_transportation_methods', function (Blueprint $table) {
                $table->id();
                $table->foreignId('service_final_detail_id')->constrained()->onDelete('cascade');
                $table->foreignId('transportation_method_id')->constrained()->onDelete('cascade');
                
                // Additional details for each transportation method
                $table->json('vehicle_details')->nullable(); // Make, model, year for vehicles
                $table->integer('capacity')->nullable(); // Number of passengers
                $table->json('insurance_info')->nullable(); // Insurance details
                $table->json('driver_license_info')->nullable(); // Driver license verification
                
                $table->timestamps();
                $table->unique(['service_final_detail_id', 'transportation_method_id'], 'svc_transport_unique');
            });
        }

        // Update listings table to add service foreign keys if not exists
        if (!Schema::hasColumn('listings', 'service_type_id')) {
            Schema::table('listings', function (Blueprint $table) {
                $table->foreignId('service_type_id')->nullable()->after('category_id')->constrained('service_types')->nullOnDelete();
                $table->foreignId('service_detail_id')->nullable()->after('service_type_id')->constrained('service_details')->nullOnDelete();
            });
        }
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
    }
};

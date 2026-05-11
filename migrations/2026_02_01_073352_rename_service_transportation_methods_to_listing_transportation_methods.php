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
        if (Schema::hasTable('service_transportation_methods')) {
            Schema::rename('service_transportation_methods', 'listing_transportation_methods');
        }

        Schema::table('listing_transportation_methods', function (Blueprint $table) {
            // Drop FK first
            if (Schema::hasColumn('listing_transportation_methods', 'service_final_detail_id')) {
                // We use a try-catch for the dropForeign in case it doesn't exist or name mismatch, though we are fairly sure of the name now.
                // Actually constraint check is hard in standard schema builder.
                // We proceed with the explicit name we found.
                $table->dropForeign('service_transportation_methods_service_final_detail_id_foreign');
            }

            // Drop unique index next
            try {
                $table->dropUnique('svc_transport_unique');
            } catch (\Exception $e) {
            }

            // Drop column last
            if (Schema::hasColumn('listing_transportation_methods', 'service_final_detail_id')) {
                $table->dropColumn('service_final_detail_id');
            }

            if (! Schema::hasColumn('listing_transportation_methods', 'listing_id')) {
                $table->foreignId('listing_id')->after('id')->constrained('listings')->cascadeOnDelete();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listing_transportation_methods', function (Blueprint $table) {
            $table->dropForeign(['listing_id']);
            $table->dropColumn('listing_id');

            $table->foreignId('service_final_detail_id')->after('id')->constrained('service_final_details')->cascadeOnDelete();
        });

        Schema::rename('listing_transportation_methods', 'service_transportation_methods');
    }
};

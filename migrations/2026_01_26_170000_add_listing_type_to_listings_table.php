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
            $table->foreignId('listing_type_id')->after('id')->nullable()->constrained()->onDelete('restrict');
        });

        // Update existing listings to have a default listing type
        // Assume existing listings are homes (listing_type_id = 1)
        \DB::statement("UPDATE listings SET listing_type_id = 1 WHERE listing_type_id IS NULL");

        // Make it required after updating existing records
        Schema::table('listings', function (Blueprint $table) {
            $table->foreignId('listing_type_id')->nullable(false)->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['listing_type_id']);
            $table->dropColumn('listing_type_id');
        });
    }
};

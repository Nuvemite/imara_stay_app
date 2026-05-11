<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Only run if the old listing_type column exists
        if (Schema::hasColumn('promotion_types', 'listing_type')) {
            // Get the actual IDs from listing_types table
            $homesId = DB::table('listing_types')->where('slug', 'homes')->value('id');
            $experiencesId = DB::table('listing_types')->where('slug', 'experiences')->value('id');

            // Update existing data using dynamic IDs
            DB::table('promotion_types')
                ->where('listing_type', 'home')
                ->update(['listing_type_id' => $homesId]);

            DB::table('promotion_types')
                ->where('listing_type', 'experience')
                ->update(['listing_type_id' => $experiencesId]);

            DB::table('promotion_types')
                ->where('listing_type', 'both')
                ->update(['listing_type_id' => null]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Get the actual IDs from listing_types table
        $homesId = DB::table('listing_types')->where('slug', 'homes')->value('id');
        $experiencesId = DB::table('listing_types')->where('slug', 'experiences')->value('id');

        // Restore listing_type enum values (approximate)
        DB::table('promotion_types')
            ->where('listing_type_id', $homesId)
            ->update(['listing_type' => 'home']);

        DB::table('promotion_types')
            ->where('listing_type_id', $experiencesId)
            ->update(['listing_type' => 'experience']);

        DB::table('promotion_types')
            ->whereNull('listing_type_id')
            ->update(['listing_type' => 'both']);
    }
};

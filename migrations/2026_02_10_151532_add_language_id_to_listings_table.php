<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->foreignId('language_id')->nullable()->after('listing_type_id')->constrained('languages')->onDelete('set null');
        });

        // Optional: Migrate existing data from JSON 'languages' array to 'language_id'
        $listings = DB::table('listings')->whereNotNull('languages')->get();
        foreach ($listings as $listing) {
            $languages = json_decode($listing->languages, true);
            if (is_array($languages) && ! empty($languages)) {
                $primaryLanguageName = $languages[0];
                $language = DB::table('languages')->where('name', $primaryLanguageName)->first();
                if ($language) {
                    DB::table('listings')->where('id', $listing->id)->update(['language_id' => $language->id]);
                }
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropForeign(['language_id']);
            $table->dropColumn('language_id');
        });
    }
};

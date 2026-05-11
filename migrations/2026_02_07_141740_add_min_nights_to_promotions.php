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
        Schema::table('promotion_types', function (Blueprint $table) {
            $table->integer('min_nights')->nullable()->after('default_value')->comment('Minimum nights required for this discount (e.g. 7 for weekly, 28 for monthly)');
        });

        Schema::table('listing_promotions', function (Blueprint $table) {
            $table->integer('min_nights')->nullable()->after('value')->comment('Override minimum nights required for this listing');
        });

        // Set default min_nights for existing promotion types
        DB::table('promotion_types')->where('slug', 'weekly')->update(['min_nights' => 7]);
        DB::table('promotion_types')->where('slug', 'monthly')->update(['min_nights' => 28]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('promotion_types', function (Blueprint $table) {
            $table->dropColumn('min_nights');
        });

        Schema::table('listing_promotions', function (Blueprint $table) {
            $table->dropColumn('min_nights');
        });
    }
};

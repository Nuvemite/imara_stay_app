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
            if (!Schema::hasColumn('listings', 'click_count')) {
                $table->integer('click_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'wishlist_count')) {
                $table->bigInteger('wishlist_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'booking_count')) {
                $table->bigInteger('booking_count')->default(0);
            }
        });

        // Add indices safely
        $indices = ['click_count', 'wishlist_count', 'booking_count', 'city', 'country', 'price_per_night', 'max_guests'];
        foreach ($indices as $column) {
            $indexName = "listings_{$column}_index";
            try {
                Schema::table('listings', function (Blueprint $table) use ($column) {
                     $table->index($column);
                });
            } catch (\Exception $e) {
                // Index likely exists, continue
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $indices = ['click_count', 'wishlist_count', 'booking_count', 'city', 'country', 'price_per_night', 'max_guests'];
            foreach ($indices as $column) {
                 $table->dropIndex([$column]); // Array syntax handles the name generation automatically
            }

            if (Schema::hasColumn('listings', 'wishlist_count')) {
                $table->dropColumn('wishlist_count');
            }
            if (Schema::hasColumn('listings', 'booking_count')) {
                $table->dropColumn('booking_count');
            }
            // We don't drop click_count as it might have existed before
        });
    }
};


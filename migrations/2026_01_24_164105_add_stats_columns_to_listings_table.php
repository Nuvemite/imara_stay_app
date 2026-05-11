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
            if (!Schema::hasColumn('listings', 'booking_count')) {
                $table->integer('booking_count')->default(0);
            }
            if (!Schema::hasColumn('listings', 'ranking_score')) {
                $table->decimal('ranking_score', 8, 2)->default(0);
            }
            if (!Schema::hasColumn('listings', 'is_guest_favorite')) {
                $table->boolean('is_guest_favorite')->default(false);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropColumn(['click_count', 'booking_count', 'ranking_score', 'is_guest_favorite']);
        });
    }
};

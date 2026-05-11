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
        Schema::create('group_discount_tiers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->onDelete('cascade');
            $table->foreignId('promotion_type_id')->constrained()->onDelete('cascade');
            $table->integer('min_guests')->default(2);
            $table->integer('discount_percentage');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            // Ensure unique combination of listing, promotion type, and min_guests
            $table->unique(['listing_id', 'promotion_type_id', 'min_guests'], 'group_tier_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('group_discount_tiers');
    }
};

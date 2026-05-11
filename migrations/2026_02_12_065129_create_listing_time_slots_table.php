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
        Schema::create('listing_time_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->onDelete('cascade');
            $table->date('date')->nullable(); // For specific date slots
            $table->tinyInteger('day_of_week')->nullable(); // 0-6 for recurring: Sunday=0
            $table->time('start_time');
            $table->time('end_time')->nullable();
            $table->integer('spots_total')->default(1);
            $table->integer('spots_booked')->default(0);
            $table->boolean('is_blocked')->default(false);
            $table->decimal('price_override', 10, 2)->nullable();
            $table->timestamps();

            $table->index('listing_id');
            $table->index('date');
            $table->index('day_of_week');
            $table->unique(['listing_id', 'date', 'start_time'], 'listing_date_time_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_time_slots');
    }
};

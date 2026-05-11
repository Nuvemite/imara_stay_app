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
        Schema::create('listing_availabilities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('listing_id')->constrained()->onDelete('cascade');
            $table->date('date');
            $table->boolean('is_blocked')->default(false);
            $table->decimal('price', 10, 2)->nullable();
            $table->string('reason')->nullable(); // e.g., 'Imported from iCal', 'Manual Block'
            $table->timestamps();

            $table->unique(['listing_id', 'date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_availabilities');
    }
};

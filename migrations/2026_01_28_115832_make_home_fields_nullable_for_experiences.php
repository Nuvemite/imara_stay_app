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
            // Make home-specific fields nullable for experiences
            $table->unsignedBigInteger('property_type_id')->nullable()->change();
            $table->unsignedBigInteger('room_type_id')->nullable()->change();
            $table->integer('bedrooms')->nullable()->change();
            $table->integer('beds')->nullable()->change();
            $table->integer('bathrooms')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            // Revert to NOT NULL with default values
            $table->unsignedBigInteger('property_type_id')->nullable(false)->default(1)->change();
            $table->unsignedBigInteger('room_type_id')->nullable(false)->default(1)->change();
            $table->integer('bedrooms')->nullable(false)->default(0)->change();
            $table->integer('beds')->nullable(false)->default(0)->change();
            $table->integer('bathrooms')->nullable(false)->default(0)->change();
        });
    }
};

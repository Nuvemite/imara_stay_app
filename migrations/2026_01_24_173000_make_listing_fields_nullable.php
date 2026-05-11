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
            $table->string('location')->nullable()->change();
            $table->string('title')->nullable()->change();
            $table->text('description')->nullable()->change();
            $table->decimal('price_per_night', 10, 2)->nullable()->change();
            $table->integer('max_guests')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->string('location')->nullable(false)->change();
            $table->string('title')->nullable(false)->change();
            $table->text('description')->nullable(false)->change();
            $table->decimal('price_per_night', 10, 2)->nullable(false)->change();
            $table->integer('max_guests')->nullable(false)->change();
        });
    }
};

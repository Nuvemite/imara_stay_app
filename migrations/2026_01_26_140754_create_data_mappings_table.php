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
        Schema::create('data_mappings', function (Blueprint $table) {
            $table->id();
            $table->string('data_key')->unique();
            $table->string('api_endpoint');
            $table->enum('method', ['GET', 'POST'])->default('GET');
            $table->json('parameters')->nullable();
            $table->integer('cache_duration')->default(3600); // 1 hour default
            $table->json('depends_on')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            
            $table->index('data_key');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('data_mappings');
    }
};

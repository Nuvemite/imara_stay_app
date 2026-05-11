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
        Schema::create('service_host_qualifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_detail_id')->constrained()->onDelete('cascade');
            $table->foreignId('qualification_type_id')->constrained()->onDelete('cascade');
            $table->string('qualification_level');
            $table->string('institution_name');
            $table->integer('year_obtained');
            $table->string('certificate_url')->nullable();
            $table->string('verification_status')->default('pending');
            $table->date('expiry_date')->nullable();
            $table->boolean('is_primary')->default(false);
            $table->softDeletes();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('service_host_qualifications');
    }
};

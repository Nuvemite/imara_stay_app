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
            // Composite index for common query: status + listing_type_id (used in homepage curation)
            // This speeds up queries filtering by both status and listing type
            if (! $this->indexExists('listings', 'listings_status_type_index')) {
                $table->index(['status_id', 'listing_type_id'], 'listings_status_type_index');
            }

            // Composite index for city queries with listing type
            // Used in getTopBookedCities and getListingsInCity
            if (! $this->indexExists('listings', 'listings_city_type_index')) {
                $table->index(['city', 'listing_type_id', 'is_soft_hidden'], 'listings_city_type_index');
            }

            // Composite index for ordering by click_count with status filter
            // Used in getMostViewed
            if (! $this->indexExists('listings', 'listings_status_click_index')) {
                $table->index(['status_id', 'click_count'], 'listings_status_click_index');
            }

            // Composite index for ordering by booking_count with status filter
            // Used in getMostBooked
            if (! $this->indexExists('listings', 'listings_status_booking_index')) {
                $table->index(['status_id', 'booking_count'], 'listings_status_booking_index');
            }

            // Composite index for ranking_score with status and listing_type
            // Used in getListingsInCity and getGuestFavorites
            if (! $this->indexExists('listings', 'listings_status_ranking_index')) {
                $table->index(['status_id', 'listing_type_id', 'ranking_score'], 'listings_status_ranking_index');
            }

            // Composite index for guest favorites query
            if (! $this->indexExists('listings', 'listings_favorite_ranking_index')) {
                $table->index(['status_id', 'is_guest_favorite', 'ranking_score'], 'listings_favorite_ranking_index');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('listings', function (Blueprint $table) {
            $table->dropIndex('listings_status_type_index');
            $table->dropIndex('listings_city_type_index');
            $table->dropIndex('listings_status_click_index');
            $table->dropIndex('listings_status_booking_index');
            $table->dropIndex('listings_status_ranking_index');
            $table->dropIndex('listings_favorite_ranking_index');
        });
    }

    /**
     * Check if an index exists on a table
     */
    private function indexExists(string $table, string $index): bool
    {
        $connection = Schema::getConnection();
        $database = $connection->getDatabaseName();

        $result = $connection->select(
            'SELECT COUNT(*) as count FROM information_schema.statistics 
             WHERE table_schema = ? AND table_name = ? AND index_name = ?',
            [$database, $table, $index]
        );

        return $result[0]->count > 0;
    }
};

<?php

declare(strict_types=1);

namespace Letsfix\Tickets\Tests;

use Letsfix\Tickets\Dependency\MissingTicketModuleException;
use Letsfix\Tickets\Dependency\TicketModuleGuard;
use PHPUnit\Framework\TestCase;

final class TicketModuleGuardTest extends TestCase
{
    public function testItAllowsInstallationWhenNativeTicketModuleIsEnabled(): void
    {
        $this->expectNotToPerformAssertions();

        TicketModuleGuard::assertEnabled(true);
    }

    public function testItFailsClearlyWhenNativeTicketModuleIsDisabled(): void
    {
        $this->expectException(MissingTicketModuleException::class);
        $this->expectExceptionMessage('Enable the native Dolibarr Ticket module before installing Letsfix Tickets.');

        TicketModuleGuard::assertEnabled(false);
    }
}
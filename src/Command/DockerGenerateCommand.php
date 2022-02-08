<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Twig\Environment;

class DockerGenerateCommand extends Command
{
    protected static $defaultName = 'app:docker:generate';

    public function __construct(
        protected string $configFile,
        protected string $renderDir,
        protected Environment $twig
    ) {
        parent::__construct();
    }


    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $configs = json_decode(file_get_contents($this->configFile), true, 512, JSON_THROW_ON_ERROR);

        foreach ($configs['docker']['images'] as $image) {
            foreach ($image['versions'] as $version) {
                foreach ($image['variants'] as $variant) {
                    $file = $this->twig->render($image['template'], [
                        'source' => $image['source'],
                        'version' => $version,
                        'variant' => $variant,
                        'maintainer' => 'Rémy BRUYERE <me@remy.ovh>',
                    ]);
                    $name = [
                        $image['name'],
                        $version,
                        $variant,
                        'Dockerfile'
                    ];

                    file_put_contents($this->renderDir.'/'.implode('.', $name), $file);
                }
            }
        }

        return Command::SUCCESS;
    }
}

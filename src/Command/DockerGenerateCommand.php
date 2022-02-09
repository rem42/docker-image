<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Twig\Environment;

class DockerGenerateCommand extends Command
{
    protected static $defaultName = 'app:docker:generate';

    public function __construct(
        protected string      $configPath,
        protected string      $renderDir,
        protected string      $projectDir,
        protected Environment $twig
    ) {
        parent::__construct();
    }

    protected function configure()
    {
        $this->addArgument('type', InputArgument::REQUIRED, 'Choose between php|yarn');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $type = $input->getArgument('type');
        $pathFile = $this->configPath.'/'.$type.'.json';

        $configs = json_decode(file_get_contents($pathFile), true, 512, JSON_THROW_ON_ERROR);

        foreach ($configs['images'] as $image) {
            foreach ($image['versions'] as $version) {
                foreach ($image['variants'] as $variant) {
                    $this->extracted($image['name'], $image['template'], $image['source'], $version, $variant);

                    if(isset($image['options'])) {
                        foreach ($image['options'] as $option) {
                            $this->extracted($image['name'], $image['template'], $image['source'], $version, $variant, $option);
                        }
                    }
                }
            }
        }

        return Command::SUCCESS;
    }


    protected function extracted(string $imageName, string $template, string $source, string $version, string $variant, ?string $option = null): void
    {
        $file = $this->twig->render($template, [
            'source' => $source,
            'version' => $version,
            'variant' => $variant,
            'maintainer' => 'Rémy BRUYERE <me@remy.ovh>',
            'option' => $option
        ]);
        $variant = $option ? $variant.'-'.$option : $variant;
        $name = [
            $imageName,
            $version,
            $variant,
        ];
        $name[] = 'Dockerfile';

        file_put_contents($this->renderDir . '/' . implode('.', $name), $file);
    }
}

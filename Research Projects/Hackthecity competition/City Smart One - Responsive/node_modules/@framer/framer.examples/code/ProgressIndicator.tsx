import * as React from "react"
import { Frame, PropertyControls, ControlType, Animatable } from "framer"

interface Props {
    indicatorColor: string
    width: number
    height: number
}

export class ProgressIndicator extends React.Component<Partial<Props>> {
    static defaultProps = {
        indicatorColor: "rgba(142,142,147,100)",
        width: 40,
        height: 40,
    }

    lastTick = performance.now()
    rotation = Animatable(0)

    static propertyControls: PropertyControls<Props> = {
        indicatorColor: { type: ControlType.Color, title: "Indicator" },
    }

    rafHandle: number

    componentDidMount() {
        this.tick()
    }

    componentWillUnmount() {
        window.cancelAnimationFrame(this.rafHandle)
    }

    tick = () => {
        const { lastTick } = this
        const currentTime = performance.now()
        this.rafHandle = window.requestAnimationFrame(this.tick)

        if (currentTime - lastTick < 120) return

        this.lastTick = currentTime
        this.rotation.set(Animatable.getNumber(this.rotation) + 360 / 12)
    }

    render() {
        const { width, height, indicatorColor } = this.props

        const dots: JSX.Element[] = []

        for (let i = 0, il = numberOfDots; i < il; i++) {
            const dot = (
                <Frame
                    key={i}
                    width={dotWidth}
                    height={dotHeight}
                    radius={dotWidth}
                    background={indicatorColor}
                    rotation={-i * (360 / numberOfDots)}
                    top={0}
                    opacity={1 - 0.05 * i}
                    originY={totalSize / 2 / dotHeight}
                />
            )
            dots.push(dot)
        }

        return (
            <Frame
                width={totalSize}
                height={totalSize}
                parentSize={{ width, height }}
                rotation={this.rotation}
                background={null}
            >
                {dots}
            </Frame>
        )
    }
}

const numberOfDots = 12
const totalSize = 20
const dotWidth = 2
const dotHeight = 5

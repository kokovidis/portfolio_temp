import * as React from "react"
import { Frame, PropertyControls, ControlType } from "framer"

interface Props {
    currentPage: number
    numberOfPages: number
    indicatorColor: string
    currentIndicatorColor: string
    nextPage: () => void
    previousPage: () => void
    width: number
    height: number
}

interface State {
    currentPage: number
    numberOfPages: number
    externalCurrentPage: number
    externalNumberOfPages: number
}

export class PageControl extends React.Component<Partial<Props>, State> {
    static defaultProps = {
        currentPage: 0,
        numberOfPages: 3,
        indicatorColor: "rgba(0,0,0,.32)",
        currentIndicatorColor: "black",
        width: 100,
        height: 20,
    }

    static propertyControls: PropertyControls<Props> = {
        currentPage: {
            type: ControlType.Number,
            min: 0,
            title: "Current",
        },
        numberOfPages: {
            type: ControlType.Number,
            min: 1,
            title: "Pages",
        },
        indicatorColor: { type: ControlType.Color, title: "Indicator" },
        currentIndicatorColor: { type: ControlType.Color, title: "Current" },
    }

    state = {
        currentPage: 0,
        numberOfPages: 7,
        externalCurrentPage: 0,
        externalNumberOfPages: 7,
    }

    next = () => {
        const { nextPage } = this.props
        const { currentPage, numberOfPages } = this.state
        if (currentPage >= numberOfPages - 1) return

        if (nextPage) {
            nextPage()
        } else {
            this.setState({ ...this.state, currentPage: currentPage + 1 })
        }
    }

    previous = () => {
        const { previousPage } = this.props
        const { currentPage } = this.state
        if (currentPage <= 0) return

        if (previousPage) {
            previousPage()
        } else {
            this.setState({ ...this.state, currentPage: currentPage - 1 })
        }
    }

    componentDidMount() {
        const { currentPage, numberOfPages } = this.props
        this.setState({ ...this.state, currentPage, numberOfPages })
    }

    static getDerivedStateFromProps(nextProps: Props, prevState: State) {
        let { currentPage, numberOfPages } = nextProps
        let { externalCurrentPage, externalNumberOfPages } = prevState
        let update: State | null = null
        if (currentPage !== externalCurrentPage) {
            if (!update) update = { ...prevState }
            update.currentPage = currentPage
            update.externalCurrentPage = currentPage
        }
        if (numberOfPages !== externalNumberOfPages) {
            if (!update) update = { ...prevState }
            update.numberOfPages = numberOfPages
            update.externalNumberOfPages = numberOfPages
        }
        return update
    }

    render() {
        const { width, height, indicatorColor, currentIndicatorColor } = this.props
        const { numberOfPages, currentPage } = this.state
        const dots: JSX.Element[] = []

        const dotsWidth = numberOfPages * dotSize + Math.max(numberOfPages - 1, 0) * spaceBetween
        const leftOffset = Math.round((width - dotsWidth) / 2)

        for (let i = 0, il = numberOfPages; i < il; i++) {
            const isCurrent = i === currentPage
            const dot = (
                <Frame
                    key={i}
                    width={dotSize}
                    height={dotSize}
                    left={i * (dotSize + spaceBetween) + leftOffset}
                    background={isCurrent ? currentIndicatorColor : indicatorColor}
                    radius={dotSize}
                />
            )
            dots.push(dot)
        }

        return (
            <Frame width={width} height={height} background={null}>
                {dots}
                <Frame left={0} height={"100%"} width={"50%"} background={null} onTap={this.previous} />
                <Frame right={0} height={"100%"} width={"50%"} background={null} onTap={this.next} />
            </Frame>
        )
    }
}

const dotSize = 7
const spaceBetween = 9
